process RAREFACTION {
    tag "qiime_rarefaction"
    conda "bioconda::qiime2=2023.7"
    container "quay.io/qiime2/amplicon:2024.5"

    input:
        path filtered_sample_table
        path rooted_tree
        path metadata  

    output:
        path "alpha-rarefaction.qzv", emit: rarefaction 
        publishDir "qiime_out", mode: 'copy'

    script:
        """
        qiime diversity alpha-rarefaction \
            --i-table ${filtered_sample_table} \
            --i-phylogeny ${rooted_tree} \
            --p-min-depth ${params.min_depth} \
            --p-max-depth ${params.max_depth} \
            --p-steps ${params.steps} \
            --p-iterations ${params.interation} \
            --m-metadata-file ${metadata} \
            --o-visualization alpha-rarefaction.qzv
        """
}

