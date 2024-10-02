def derivation_env_vars:
  map_values(
    .env.__json
      | fromjson
      | with_entries(select(.key | test("^[0-9A-Z_]+$")))
  );

def transition_uri_index:
  [ paths | sort | join(".") ]
    | sort
    | map({ key: ., value: @uri })
    | from_entries;
