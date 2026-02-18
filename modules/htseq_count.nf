process HTSEQ_COUNT {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign_htseq'

    input:
    tuple val(meta), path(bam)
    tuple val(meta), path(strandness)
    path gtf
    

    output:
    tuple val(meta), path("${meta.sample}_htseq.counts"), emit: htseq_counts

    publishDir { "HTSeq_counts/" }, mode: 'symlink'

    script:
    """

    htseq_strand=\$(cat ${strandness})
    htseq-count -r pos -t exon --additional-attr gene_name --strand \${htseq_strand} --nonunique random --max-reads-in-buffer 100000000 ${bam} ${gtf} > ${meta.sample}_htseq.counts 

    """
}