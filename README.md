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
