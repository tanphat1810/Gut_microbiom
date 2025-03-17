process BUILD_PHYLOGENETIC_TREE {
    tag "qiime2_phylogenetic_tree"
    container "quay.io/qiime2/amplicon:2024.5"
    input:
        path rep_seqs  
    output:
        path "aligned-rep-seqs.qza", emit: aligned_rep_seqs
        path "masked-aligned-rep-seqs.qza", emit: masked_aligned_rep_seqs
        path "unrooted-tree.qza", emit: unrooted_tree
        path "rooted-tree.qza", emit: rooted_tree
        publishDir "qiime_out", mode: 'copy'
    script:
        """
        qiime phylogeny align-to-tree-mafft-fasttree \
              --i-sequences ${rep_seqs} \\
              --o-alignment aligned-rep-seqs.qza \\
              --o-masked-alignment masked-aligned-rep-seqs.qza \\
              --o-tree unrooted-tree.qza \\
              --o-rooted-tree rooted-tree.qza
        """
}

