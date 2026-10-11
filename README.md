# IMP-study

This script help extract the IMP gene with tranposon and integrons

```
bash IMP_gene_extraction.sh
```

## Annotate the extracted gene

```
for i in */IMP_20kb.fasta; do
    sample_dir=$(dirname "$i")
    bakta "$i" --output "$sample_dir/IMP_gene_bakta" --threads 40
done
```


## Checking if the AMR gene is on the plasmid or chromosome
Run Mob_recon
```
mkdir -p zMob_suite
ls *.fasta | parallel -j 3 -v --progress 'base=$(basename {} .fasta); mkdir -p zMob_suite/"$base" && mob_recon -i {} -o zMob_suite/"$base" -n 20 -s "$base" -c --force'

```
Copy all the amrfinder.out to a folder with sample name 
```
ls | head                                                                                                               
DRR065577amrfinder.out                                                                                                                             
DRR065578amrfinder.out                                                                                                                             
DRR065598amrfinder.out                                                                                                                             
```
Extract the contig number where IMP is located

```
awk -F'\t' -v OFS='\t' '                                                                                                
FNR==1 { for (i=1; i<=NF; i++) {                                                                                                                   
           if ($i=="Contig id") c=i                                                                                                                
           if ($i=="Start") s=i                                                                                                                    
           if ($i=="Stop")  e=i                                                                                                                    
           if ($i=="Element symbol" || $i=="Gene symbol") g=i }                                                                                    
         next }                                                                                                                                    
$g ~ /^blaIMP/ { iso=FILENAME; sub(/amrfinder\.out$/, "", iso); print iso, $c, $s, $e, $g }' *amrfinder.out > zImp.tab 

printf "sample_id\tcontig\tmolecule_type\tprimary_cluster_id\tcontig_size\n" > zIMP_mob_results.tsv

````
