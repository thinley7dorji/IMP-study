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

```
mkdir -p zMob_suite
ls *.fasta | parallel -j 3 -v --progress 'base=$(basename {} .fasta); mkdir -p zMob_suite/"$base" && mob_recon -i {} -o zMob_suite/"$base" -n 20 -s "$base" -c --force'


printf "sample_id\tcontig\tmolecule_type\tprimary_cluster_id\tcontig_size\n" > zIMP_mob_results.tsv

````
