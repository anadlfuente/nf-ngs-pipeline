
process STAR_TWOPASS_2 {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    publishDir ("${params.outdir}/NGSalign_output/STAR/Pass2/${meta.sample}", mode: 'link')

     input:
    tuple val(meta), path(fastq1), path(fastq2), path(genome_dir)
    path gtf
    val read_length
    val threads
    val PL
    val LB
    val maxRAM

    output:
    tuple val(meta), path("${meta.sample}.SJ.out.tab"), emit: sj_out
    tuple val(meta), path("${meta.sample}.Log.final.out"), emit: log_final
    tuple val(meta), path("${meta.sample}.Log.out"), emit: log_out
    tuple val(meta), path("${meta.sample}.Log.progress.out"), emit: log_progress
    tuple val(meta), path("${meta.sample}.Chimeric.out.junction"), emit: chimeric_junction
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.bam"), emit: bam
    tuple val(meta), path("${meta.sample}.Aligned.sortedByCoord.out.bam.bai"), emit: bam_index
    tuple val(meta), path("${meta.sample}.ReadsPerGene.out.tab"), emit: reads_per_gene

    script:
    """
    # Detect gz
    if [[ "${fastq1}" == *.gz ]]; then
        read_cmd='zcat'
    else
        read_cmd='cat'
    fi

    # BAM header
    ID=${meta.sample}
    SM=${meta.sample}
    PU=\$(${read_cmd} ${fastq1} | head -1 | sed 's/[:].*//' | sed 's/@//')
    RG="@RG\\tID:${ID}\\tSM:${SM}\\tPL:${PL}\\tLB:${LB}\\tPU:${PU}"
	RG2="ID:${ID} SM:${SM} PL:${PL} LB:${LB} PU:${PU}"

    STAR --genomeLoad NoSharedMemory --limitBAMsortRAM ${maxRAM}00000000 --outSAMattrRGline ${RG2} --genomeDir ${genome_dir} --chimSegmentMin 12 --chimOutType Junctions WithinBAM  --readFilesCommand ${read_cmd} --readFilesIn ${fastq1} ${fastq2} --sjdbGTFfile ${gtf} --runThreadN ${threads} --outFileNamePrefix ${meta.sample}. --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts  --limitSjdbInsertNsj 5000000 --outSAMunmapped Within --outFilterMultimapNmax 50 --outSAMstrandField intronMotif

    # Index BAM
    samtools index -@ ${threads} ${meta.sample}.Aligned.sortedByCoord.out.bam

    """
}