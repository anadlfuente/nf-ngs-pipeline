
process RSeQC_junctionsaturation {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.junction_saturation_log.txt"), emit: log_juncsat
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junctionSaturation_plot.pdf"), emit: juncsat_pdf
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.rseqc.junctionSaturation_plot.r"), emit: juncsat_r

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """
    junction_saturation.py -i ${bam} -o ${meta.sample}.Aligned.sortedByCoord.out.rseqc -r ${bed} > /dev/null 2> ${meta.sample}.Aligned.sortedByCoord.out.junction_saturation_log.txt 

    """
}