
process RSeQC_readdistribution {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_distribution_log.txt"), emit: log_readdist
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_distribution.txt"), emit: readdist

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

    read_distribution.py -i ${bam} -r ${bed} > ${meta.sample}.Aligned.sortedByCoord.out.read_distribution.txt 2> ${meta.sample}.Aligned.sortedByCoord.out.read_distribution_log.txt

    """
}