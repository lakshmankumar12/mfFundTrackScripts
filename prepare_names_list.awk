BEGIN {
  FS=";"
}
/Schemes/ {
  current_scheme=$0;
  gsub("[[:space:]]*$","",current_scheme);
  next;
}
/;/ {
  if ( current_scheme!="" ) {
    print $4 "; ;" current_scheme ";"
  }
  next
}
