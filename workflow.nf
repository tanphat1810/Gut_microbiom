#!/usr/bin/env nextflow
nextflow.enable.dsl=2
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PacBio HiFi 16S rRNA Nextflow Workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// **IMPORT MODULES**
include { FASTQC_RAW } from './modules/fastqc_raw.nf'
include { MULTIQC_RAW } from './modules/multiqc_raw.nf'
include { SEQKIT_FILTER } from './modules/seqkit.nf'
include { FASTQC_FILTERED } from './modules/fastqc_filtered.nf'
include { MULTIQC_FILTERED } from './modules/multiqc_filtered.nf'
include { MANIFEST_TSV } from './modules/manifest_tsv.nf'
include { QIIME_IMPORT } from './modules/qiime_import.nf'
include { DENOISE_CCS } from './modules/denoise-ccs.nf'
include { FILTER_FEATURES } from './modules/filter_features.nf'
include { FILTER_SAMPLES } from './modules/filter_sample.nf'
include { FILTER_SEQS } from './modules/filterseqs.nf'
include { CLASSIFY_TAXONOMY } from './modules/classify_taxonomy.nf'
include { BUILD_PHYLOGENETIC_TREE } from './modules/build_phylogenetictree.nf'
include { RAREFACTION } from './modules/rarefaction.nf'
include { RAREFY } from './modules/rarefy.nf'
include { BARPLOT } from './modules/taxonomy_barplot.nf'
include { ALPHA_BETA_DEVERSITY } from './modules/deversity.nf'
         channel_reads = Channel.fromPath(params.input)
                           .map { [meta: [id: it.baseName], file: it]}
workflow PACBIO_16S_PIPELINE {
         
         FASTQC_RAW(channel_reads)
         multiqc_raw_input = FASTQC_RAW.out.zip.map { meta, zip_file -> zip_file }.collect()
         multiqc_raw_result = MULTIQC_RAW(multiqc_raw_input)
         SEQKIT_FILTER(channel_reads)
         filtered_reads = SEQKIT_FILTER.out.filtered
                          .map { meta, file -> tuple(meta, file) } 
                          .view()
         FASTQC_FILTERED(filtered_reads)
         multiqc_filtered_input = FASTQC_FILTERED.out.zip.map { meta, zip_file -> zip_file }.collect()
         multiqc_filtered_result = MULTIQC_FILTERED(multiqc_filtered_input)
         filtered_reads_path = SEQKIT_FILTER.out.filtered
                          .map { it[1] }  
                          .collect()
                          .view()
         MANIFEST_TSV(filtered_reads_path)
         manifest = MANIFEST_TSV.out
                          .filter { it.name.endsWith('.tsv') }  
                          .flatten()
                          .view()
         QIIME_IMPORT(manifest)
         qiime_data = QIIME_IMPORT.out.qiime_artifact
                          .toList()
                          .view()
         DENOISE_CCS(qiime_data)
         FILTER_FEATURES(DENOISE_CCS.out.feature_table)
         FILTER_SAMPLES(FILTER_FEATURES.out.filtered_feature_table)
         FILTER_SEQS(
                          DENOISE_CCS.out.representative_sequences,
                          FILTER_SAMPLES.out.filtered_sample_table
                    )
         classifier_path = file(params.classifier)
         CLASSIFY_TAXONOMY(
                          FILTER_SEQS.out.filtered_representative_seqs,
                          classifier_path
                    )
         BUILD_PHYLOGENETIC_TREE(FILTER_SEQS.out.filtered_representative_seqs)
         metadata_file = file(params.metadata)  
         RAREFACTION(
                          FILTER_SAMPLES.out.filtered_sample_table,
                          BUILD_PHYLOGENETIC_TREE.out.rooted_tree,
                          metadata_file)
         RAREFY(FILTER_SAMPLES.out.filtered_sample_table)
         BARPLOT(
                          CLASSIFY_TAXONOMY.out.classified_taxonomy,
                          RAREFY.out.rarefied_table,
                          metadata_file
                    )   
         ALPHA_BETA_DEVERSITY(FILTER_SAMPLES.out.filtered_sample_table,
                              BUILD_PHYLOGENETIC_TREE.out.rooted_tree,
                              metadata_file)
                          }
