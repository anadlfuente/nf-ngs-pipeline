
process RSeQC_inferexperiment {
    tag "{meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    publishDir ("${params.outdir}/NGSalign_output/RSeQC/${meta.sample}", mode: 'link')

    input:
    tuple val(meta), path(bam)
    path gtf
    val threads

    output:
    tuple val(meta), path("${meta.sample}.SJ.out.tab"), emit: sj_out
    tuple val(meta), path("${meta.sample}.Log.final.out"), emit: log_final
    tuple val(meta), path("${meta.sample}.Log.out"), emit: log_out
    tuple val(meta), path("${meta.sample}.Log.progress.out"), emit: log_progress
    tuple val(meta), path("${meta.sample}._STARgenome"), emit: genome_dir

    script:
    """
    ## Prepare annotation bed
	gtf_bed=${gtf%.gtf}.bed
	if [ ! -f ${gtf_bed} ]; then
		gtf2bed ${gtf} > ${gtf_bed}
	fi

    ## Create sample directory
    mkdir -p ${meta.sample}
    cd ${meta.sample}

    check_intermediates RSeqC ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam &
	infer_experiment.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -r ${gtf_bed} > ${name}.Aligned.sortedByCoord.out.infer_experiment.txt 2> ${name}.Aligned.sortedByCoord.out.infer_experiment_log.txt
		wait
	junction_annotation.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -o ${name}.Aligned.sortedByCoord.out.rseqc -r ${gtf_bed} > /dev/null 2> ${name}.Aligned.sortedByCoord.out.junction_annotation_log.txt &
	bam_stat.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam > ${name}.Aligned.sortedByCoord.out.bam_stat.txt 2> ${name}.Aligned.sortedByCoord.out.bam_stat_log.txt
		wait
	junction_saturation.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -o ${name}.Aligned.sortedByCoord.out.rseqc -r ${gtf_bed} > /dev/null 2> ${name}.Aligned.sortedByCoord.out.junction_saturation_log.txt &
	Vainner_distance.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -o ${name}.Aligned.sortedByCoord.out.rseqc -r ${gtf_bed} > /dev/null 2> ${name}.Aligned.sortedByCoord.out.inner_distance_log.txt &
	read_distribution.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -r ${gtf_bed} > ${name}.Aligned.sortedByCoord.out.read_distribution.txt 2> ${name}.Aligned.sortedByCoord.out.read_distribution_log.txt
		wait
		#read_duplication.py -i ${starDir}/${name}/${name}.Aligned.sortedByCoord.out.bam -o ${name}.Aligned.sortedByCoord.out.read_duplication > /dev/null 2> ${name}.Aligned.sortedByCoord.out.read_duplication_log.txt
		keepTrace get_strandness

    """
}