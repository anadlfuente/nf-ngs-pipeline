
process STAR_TWOPASS_GENOME{
    tag "${exp}"

    conda '/data/programs/mambaforge/envs/NGSalign'
    
    input: 
    tuple val(exp), path(sj_outs)
    path genome
    path gtf
    val read_length
    val threads 

    output:
    tuple val(exp), path("twopass_genome"), emit: twopass_genome_dir

    script:
    """
    
    mkdir -p twopass_genome
    cd twopass_genome

    ## Combine SJ,out.tab
    cat ${sj_outs.join(' ')} | awk '($5>0 && $7>2 && $6==0)' | cut -f1-6 | sort | uniq > ${exp}_merged_SJ.out.tab

	keepTrace STAR --runMode genomeGenerate --genomeDir twopass_genome --genomeFastaFiles ${genome} --sjdbGTFfile ${gtf} --runThreadN ${threads} --sjdbOverhang $((${read_length}-1)) --sjdbFileChrStartEnd ${exp}_merged_SJ.out.tab 

    """
}