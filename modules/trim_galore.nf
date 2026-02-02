
process TRIM_GALORE {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    
    cpus { 
        params.threads > 14 ? 4 :
        params.threads > 11 ? 3 :
        params.threads > 8  ? 2 : 1
    }


    publishDir ("${params.outdir}/NGSalign_output/Trim_galore/${meta.sample}", mode: 'copy')


    input:
    tuple val(meta), path(fastq1), path(fastq2)

    output:
    tuple val(meta), path("${meta.sample}*_val_1.fq.gz"), emit: trim_fq1
    tuple val(meta), path("${meta.sample}*_val_2.fq.gz"), emit: trim_fq2
    tuple val(meta), path("${meta.sample}*_R1_*_trimming_report.txt"), emit: trim_report1
    tuple val(meta), path("${meta.sample}*_R2_*_trimming_report.txt"), emit: trim_report2
    tuple val(meta), path("${meta.sample}*_val_1_fastqc.html"), emit: fastqc_html1
    tuple val(meta), path("${meta.sample}*_val_2_fastqc.html"), emit: fastqc_html2
    tuple val(meta), path("${meta.sample}*_val_1_fastqc.zip"), emit: fastqc_zip1
    tuple val(meta), path("${meta.sample}*_val_2_fastqc.zip"), emit: fastqc_zip2

    script:
    """
    trim_galore --stringency 10 --illumina --paired --fastqc --cores ${task.cpus} ${fastq1} ${fastq2}  

    """
}