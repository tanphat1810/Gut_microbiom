process BARPLOT {
    tag "qiime2_barplot"
    conda "bioconda::qiime2=2024.5"
    container 'quay.io/qiime2/amplicon:2024.5'  
    input:
    path classified_taxonomy      
    path rarefied_table    
    path metadata           
    output:
    path "taxonomy_barplot.qzv", emit: barplot_qzv  
    publishDir "qiime_out", mode: 'copy'  

    script:
    """
    qiime taxa barplot \\
        --i-table ${rarefied_table} \\
        --i-taxonomy ${classified_taxonomy} \\
        --m-metadata-file ${metadata} \\
        --o-visualization taxonomy_barplot.qzv
    """
}
