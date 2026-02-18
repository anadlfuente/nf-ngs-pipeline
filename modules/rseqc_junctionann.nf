process RSeQC_junctionannotation {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.junction_annotation_log.txt"), emit: log_juncann
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junction_plot.r"), emit: juncann_plot
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junction.xls"), emit: juncann_junc_xls
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.splice_events.pdf"), emit: juncann_splice_events
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.splice_junction.pdf"), emit: juncann_junction
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junction.bed"), emit: juncann_bed
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junction.Interact.bed"), emit: juncann_int_bed

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

    junction_annotation.py -i ${bam} -o ${meta.sample}.Aligned.sortedByCoord.out.rseqc -r ${bed} > /dev/null 2> ${meta.sample}.Aligned.sortedByCoord.out.junction_annotation_log.txt 

    """
}