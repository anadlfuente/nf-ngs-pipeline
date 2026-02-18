
process RSeQC_readduplication {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication_log.txt"), emit: log_readdup
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication.txt"), emit: readdup

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

	read_duplication.py -i ${bam} -o ${meta.sample}.Aligned.sortedByCoord.out.read_duplication > /dev/null 2> ${meta.sample}.Aligned.sortedByCoord.out.read_duplication_log.txt

    """
}