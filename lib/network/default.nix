{lib, ...}:
with lib; let
  ## Functions
  # Generate a 128bits hash from a secret
  str_to_hash = string:
    builtins.substring 0 32 (builtins.hashString "sha256" string);

  # Add a ":" each n(step) characters
  hash_to_address = string: step:
    lib.concatStringsSep ":" (
      lib.forEach (lib.range 0 (lib.stringLength string / step - 1)) (
        i: builtins.substring (i * step) step string
      )
    );
in rec {
  # Generate a mac address from a sting
  str_to_mac = string: let
    hash = builtins.substring 0 12 (str_to_hash string);
    vec_hash = stringToCharacters hash;

    sanitized_hash = concatStrings (
      imap0 (i: v:
        if i == 1
        then "2" # SLAP quadrant (AAI)
        else v) (stringToCharacters hash)
    );
    step = 2;
    mac = hash_to_address sanitized_hash step;
  in
    mac;

  # Generate an ipv6 from a string
  str_to_ipv6 = string: let
    hash = str_to_hash string;
    step = 4;
    ipv6 = hash_to_address hash step;
  in
    ipv6;

  # Generate an ipv6 iid from a string
  str_to_iid = string: let
    # Take only the iid part of the ipv6
    hash = builtins.substring 16 16 (str_to_hash string);
    step = 4;
    iid = hash_to_address hash step;
  in
    iid;

  # ## Globals
  # iid = cfg.network.privacy.ipv6.iid;
  # computed_iid = str_to_iid cfg.network.privacy.ipv6.secret;
  # token =
  #   if (!isNull iid)
  #   then iid
  #   else computed_iid;
  #
  # computed_mac = str_to_mac cfg.network.privacy.ipv6.secret;
}
