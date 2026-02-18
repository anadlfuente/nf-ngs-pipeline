
process RSeQC_vainnerdistance {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.inner_distance_freq.txt"), emit: inndist_freq
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.inner_distance.txt"), emit: inndist
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.inner_distance_plot.pdf"), emit: inndist_plot_pdf
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.inner_distance_plot.r"), emit: inndist_plot_r


    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

    inner_distance.py -i ${bam} -o ${meta.sample}.Aligned.sortedByCoord.out.rseqc -r ${bed} > /dev/null 2> ${meta.sample}.Aligned.sortedByCoord.out.inner_distance_log.txt 

    """
}