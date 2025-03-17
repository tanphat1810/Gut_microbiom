process RAREFY {
        tag "qiime_rarefy"
        conda "bioconda::qiime2=2023.7"
        container "quay.io/qiime2/amplicon:2024.5"
        input:
        path filtered_sample_table
        output:
        path "rarefied_table.qza", emit: rarefied_table
        publishDir "qiime_out", mode: 'copy'
        script:
        """
        qiime feature-table rarefy \
        --i-table ${filtered_sample_table} \
        --p-sampling-depth ${params.rarefy_depth} \
        --o-rarefied-table rarefied_table.qza
        """
}

