{
  lib,
  inputs,
  ...
}: let
  # Power base 10
  pow = n: i:
    if i == 1
    then n
    else if i == 0
    then 1
    else n * pow n (i - 1);
in {
  # Set dedicated RAM in GB (ex: 16),
  # and hugepage size in kb (default 2048)
  ram_to_hugepage = dedicated_ram: hugepage_size: toString ((dedicated_ram * pow 1024 2) / hugepage_size);
}
