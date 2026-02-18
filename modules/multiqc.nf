process MULTIQC {
    tag "multiqc"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    path work_dir
    output:
    path "multiqc_report.html"
    path "multiqc_data/"

    publishDir { "multiqc/" }, mode: 'symlink'

    script:
    """
    multiqc ${work_dir}

    """
}