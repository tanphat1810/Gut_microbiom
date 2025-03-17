process ALPHA_BETA_DEVERSITY {
        tag "alpha_beta"
        conda "bioconda::qiime2=2023.7"
        container "quay.io/qiime2/amplicon:2024.5"
        input:
             path filtered_sample_table
             path rooted_tree
             path metadata 
        output:
             path "core-metrics-results/*", emit: core_metrics_results
        script:
             """
            qiime diversity core-metrics-phylogenetic \
                  --i-table ${filtered_sample_table} \
                  --i-phylogeny ${rooted_tree} \
                  --p-sampling-depth ${params.deversity_depth} \
                  --m-metadata-file ${metadata} \
                  --output-dir core-metrics-results
            """
}
