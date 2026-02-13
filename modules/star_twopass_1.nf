
process STAR_TWOPASS_1 {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(fastq1), path(fastq2)
    path refDir
    path gtf
    val threads

    output:
    path("${meta.sample}.SJ.out.tab"), emit: sj_out
    tuple val(meta), path("${meta.sample}.Log.final.out"), emit: log_final
    tuple val(meta), path("${meta.sample}.Log.out"), emit: log_out
    tuple val(meta), path("${meta.sample}.Log.progress.out"), emit: log_progress
    tuple val(meta), path("${meta.sample}._STARgenome"), emit: genome_dir

    cpus { threads }

    publishDir { "STAR/Pass1/${meta.sample}" }, mode: 'symlink'

    script:
    """
	STAR --genomeLoad NoSharedMemory --genomeDir ${refDir} --readFilesCommand ${fastq1.toString().endsWith('.gz') ? 'zcat' : 'cat'} --readFilesIn ${fastq1} ${fastq2} --sjdbGTFfile ${gtf} --runThreadN ${task.cpus} --outSAMtype None --outFileNamePrefix ${meta.sample}. --outSAMstrandField intronMotif

    """
}