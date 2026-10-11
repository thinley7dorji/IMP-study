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

# Copy all the contig_report.txt into one folder and combine them


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

I have copied the imp location and combined contigs to one folder

```
head zImp.tab                                                                                                           
DRR065577       contig00098     339     1076    blaIMP-4                                                                                           
DRR065578       contig00087     760     1497    blaIMP-4                                                                                           
DRR065598       contig00048     359     1096    blaIMP-4                                                                                           
```                                                                                                                    

Extracting the location of amr gene
```
awk -F'\t' -v OFS='\t' '
# read zImp.tab: remember each isolate + contig
FNR==NR { hit[$1"|"$2]=$0; next }

# header lines of the contig report (handles repeated headers from concatenating)
/molecule_type/ { for (i=1;i<=NF;i++) {
                    if ($i=="sample_id")          s=i
                    if ($i=="molecule_type")      m=i
                    if ($i=="primary_cluster_id") k=i
                    if ($i=="contig_id")          ci=i
                    if ($i=="size")               sz=i }
                  next }

# match isolate + contig
{ split($ci, id, " "); key=$s"|"id[1]
  if (key in hit) { print hit[key], $m, $k, $sz; seen[key]=1 } }

END { for (x in hit) if (!(x in seen)) print hit[x], "not_found", "-", "-" }
' zImp.tab zcombined_contig_report.tab > imp_location.tab
```
```
head imp_location.tab                                                                                           
DRR065577       contig00098     339     1076    blaIMP-4        plasmid AA002   1835                                                               
DRR065578       contig00087     760     1497    blaIMP-4        plasmid AA002   1601                                                               
DRR065598       contig00048     359     1096    blaIMP-4        plasmid AA860   3389                                                               
```
