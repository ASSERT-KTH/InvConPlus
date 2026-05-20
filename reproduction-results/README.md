# InvCon+ Reproducibility Study

This repository contains the reproduction of **InvCon+**, a dynamic invariant detector
for Ethereum smart contracts, originally published at:
> Franklinliu/InvConPlus-Tool

---

## Environment

- **Server**: repairnator (Ubuntu)
- **Python**: 3.10 (virtualenv at `invconplus-env/`)
- **chifra**: TrueBlocks v6.5.0 (installed at `/mnt/ssd2/angela/chifra/`)
- **Slither**: 0.9.0
- **crytic-compile**: 0.3.11

### Setup

```bash
cd ~/InvConPlus
source invconplus-env/bin/activate
export RPC_URL="<DWELLIR_ARCHIVE_ENDPOINT>"
export ETHERSCAN_API_KEY="<YOUR_KEY>"
```

### Running a contract

```bash
python3 -m invconplus.main --address <CONTRACT_ADDRESS> 
```

For contracts with fewer than 50 transactions, lower `--minSupport`:
```bash
python3 -m invconplus.main \
  --address <CONTRACT_ADDRESS> \
  --minSupport <number>
```

---

## References

- Original repository: https://github.com/Franklinliu/InvConPlus-Tool
- Fork: https://github.com/ASSERT-KTH/InvConPlus
- Paper: InvCon+, ASE 2022
