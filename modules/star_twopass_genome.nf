
process STAR_TWOPASS_GENOME{

    conda '/data/programs/mambaforge/envs/NGSalign'
    
    input: 
    path(sj_outs)
    path genome
    path gtf
    val read_length
    val threads 

    output:
    path("twopass_genome"), emit: twopass_genome_dir

    publishDir "STAR/twopass_genome", mode: 'symlink'

    cpus { threads }

    script:
    """
    
    mkdir -p twopass_genome

    ## Combine SJ,out.tab
    cat ${sj_outs.join(' ')} | awk '(\$5>0 && \$7>2 && \$6==0)' | cut -f1-6 | sort | uniq > twopass_genome/merged_SJ.out.tab

    cd twopass_genome
	STAR --runMode genomeGenerate --genomeDir twopass_genome --genomeFastaFiles ${genome} --sjdbGTFfile ${gtf} --runThreadN ${task.cpus} --sjdbOverhang \$((${read_length}-1)) --sjdbFileChrStartEnd merged_SJ.out.tab 

    """
}