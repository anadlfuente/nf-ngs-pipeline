
process RSeQC_inferexperiment {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(bam)
    path bed

    output:
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.infer_experiment_log.txt"), emit: log_infer
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.infer_experiment.txt"), emit: infer_experiment

    publishDir { "RSeQC/${meta.sample}/" }, mode: 'symlink'

    script:
    """

	infer_experiment.py -i ${bam} -r ${bed} > ${meta.sample}.Aligned.sortedByCoord.out.infer_experiment.txt 2> ${meta.sample}.Aligned.sortedByCoord.out.infer_experiment_log.txt

    """
}