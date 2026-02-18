
process RSeQC_bamstat {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.bam_stat_log.txt"), emit: log_bamstat
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.bam_stat.txt"), emit: bam_stat

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """
    bam_stat.py -i ${bam} > ${meta.sample}.Aligned.sortedByCoord.out.bam_stat.txt 2> ${meta.sample}.Aligned.sortedByCoord.out.bam_stat_log.txt

    """
}