#!/bin/sh

echo This file recreates localization_data.h according resource.h
echo

# check that sed is available
type -P sed &>/dev/null || { echo "sed command not found. Aborting." >&2; exit 1; }

# Create the first sed command file
cat > cmd.sed <<\_EOF
# Insert header
1i /*\
 * Rufus: The Reliable USB Formatting Utility\
 * Localization tables - autogenerated from resource.h\
 * Copyright © 2013-2022 Pete Batard <pete@akeo.ie>\
 *\
 * This program is free software: you can redistribute it and/or modify\
 * it under the terms of the GNU General Public License as published by\
 * the Free Software Foundation, either version 3 of the License, or\
 * (at your option) any later version.\
 *\
 * This program is distributed in the hope that it will be useful,\
 * but WITHOUT ANY WARRANTY; without even the implied warranty of\
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\
 * GNU General Public License for more details.\
 *\
 * You should have received a copy of the GNU General Public License\
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.\
 */\
\
#include <windows.h>\
#include "resource.h"\
#include "localization.h"\
\
#define LOC_CTRL(x)  { #x, x }\
#define LOC_DLG(x)   { x, NULL, {NULL, NULL} }\
\
// Control IDs\
const loc_control_id control_id[] = {\
	// The dialog IDs must come first

# Add the control entries - must be in IDD_, IDC_, IDS_ or MSG_ (and not contain _XP or _RTL suffix)
s/^.* IDD_.*_RTL .*//
s/^.* IDD_.*_XP .*//
s/^#define \([I|M][D|S][D|C|S|G]_[^ ]*\) .*/\	LOC_CTRL(\1),/

# Add standard IDs from windows.h and close table
$a\
	LOC_CTRL(IDOK),\
	LOC_CTRL(IDCANCEL),\
	LOC_CTRL(IDABORT),\
	LOC_CTRL(IDRETRY),\
	LOC_CTRL(IDIGNORE),\
	LOC_CTRL(IDYES),\
	LOC_CTRL(IDNO),\
	LOC_CTRL(IDCLOSE),\
	LOC_CTRL(IDHELP),\
\};\

# Remove everything else
/^[#|\/]/d
/^$/d
_EOF

# Run first part
sed -f cmd.sed resource.h > localization_data.h

# Create the second sed command file
cat > cmd.sed <<\_EOF

# Insert dialog table header
1i // Dialog data\
loc_dlg_list loc_dlg[] = {

# Add the dialog entries - must start with IDD_
s/^.* IDD_.*_RTL .*//
s/^.* IDD_.*_XP .*//
s/^#define \(IDD_[^ ]*\) .*/\	LOC_DLG(\1),/

# Close the table
$a\
};

# Remove everything else
/^[#|\/]/d
/^$/d
_EOF

# Run second part
sed -f cmd.sed resource.h >> localization_data.h

rm cmd.sed
echo Done.
