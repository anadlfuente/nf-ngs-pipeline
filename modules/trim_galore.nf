
process TRIM_GALORE {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    
    cpus { 
        params.threads > 14 ? 4 :
        params.threads > 11 ? 3 :
        params.threads > 8  ? 2 : 1
    }

    input:
    tuple val(meta), path(fastq1), path(fastq2)

    output:
    tuple val(meta), path("${meta.sample}*_val_1.fq.gz"), path("${meta.sample}*_val_2.fq.gz"), emit: trim_fastqs
    tuple val(meta), path("${meta.sample}*_R1_*_trimming_report.txt"), path("${meta.sample}*_R2_*_trimming_report.txt"), emit: trim_report
    tuple val(meta), path("${meta.sample}*_val_1_fastqc.html"), path("${meta.sample}*_val_2_fastqc.html"), emit: fastqc_html
    tuple val(meta), path("${meta.sample}*_val_1_fastqc.zip"), path("${meta.sample}*_val_2_fastqc.zip"), emit: fastqc_zip

    script:
    """
    trim_galore --stringency 10 --illumina --paired --fastqc --cores ${task.cpus} ${fastq1} ${fastq2}  

    """
}