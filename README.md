# Red Hat Openshift GitOps Dex

This repo holds configurations to build upstream Dex via Konflux CI for Red Hat Openshift GitOps.

## How to update Dex version?

Use `make update-dex ref=<commit-or-tag>` target to update dex submodule. 

Example:
```bash
make update-dex ref=v2.41.1
```

After running the target, verify the changes and commit them.

## How to validate changes locally?

## How to update prefetch dependencies?

