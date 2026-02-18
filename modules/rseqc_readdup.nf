
process RSeQC_readduplication {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication_log.txt"), emit: log_readdup
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication.DupRate_plot.r"), emit: readdup_plotr
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication.DupRate_plot.pdf"), emit: readdup_plotpdf
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication.seq.DupRate.xls"), emit: readdup_seq
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.read_duplication.pos.DupRate.xls"), emit: readdup_pos

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

	read_duplication.py -i ${bam} -o ${meta.sample}.Aligned.sortedByCoord.out.read_duplication > /dev/null 2> ${meta.sample}.Aligned.sortedByCoord.out.read_duplication_log.txt

    """
}