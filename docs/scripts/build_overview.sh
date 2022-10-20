#! /usr/bin/env bash

cd ..
[[ -d generated ]] || mkdir generated
cd generated

package_list='index.md'

last_group='.'

echo -e "# Package list\n" > $package_list

# /bin/ls -1 easyconfigs/*/*/*.eb | sed -e 's|easyconfigs/\(.*/.*\)/.*\.eb|\1|' | sort -uf


for package_dir in $(/bin/ls -1 ../../easybuild/easyconfigs/*/*/*.eb | sed -e 's|.*/easyconfigs/\(.*/.*\)/.*\.eb|\1|' | sort -uf)
do
	
	>&2 echo "Processing $package_dir..." 
	
	# Extract the first letter and the name of the package.
	package=${package_dir##[0-9a-z]/}
	group=${package_dir%%/$package}
	
	>&2 echo "Identified group $group, package $package"

	mkdir -p $package_dir
	package_file="$package_dir/package.md"

    # Create the package file.

    echo -e "[[package list]](../../index.md)\n" >$package_file
	echo -e "# $package\n" >>$package_file

	#
	# Generate the user documentation if a USAGE.md file exists.
	#
    usage="../../easybuild/easyconfigs/$package_dir/USAGE.md"
	if [[ -f $usage ]]
    then
	    echo -e "## User documentation\n" >>$package_file
		egrep -v "^# " $usage | sed -e 's|^#|##|' >>$package_file
	fi

    #
	# Generate a list of EasyConfig files
	#

	echo -e "## Available EasyConfigs\n" >>$package_file

    prefix="../../easybuild/easyconfigs/$package_dir"
	for file in $(/bin/ls -1 $prefix/*.eb | sort -f)
	do

        easyconfig="${file##$prefix/}"
		easyconfig_md="$package_dir/${easyconfig/.eb/.md}"

		>&2 echo "Processing $easyconfig, generating $easyconfig_md..."

        echo -e "[[$package]](package.md) [[package list]](../../index.md)\n" >$easyconfig_md
        echo -e "# $easyconfig\n" >>$easyconfig_md
		echo -e '``` python\n' >>$easyconfig_md
		cat $file >>$easyconfig_md
		echo -e '```\n' >>$easyconfig_md
        echo -e "[[$package]](package.md) [[package list]](../../index.md)" >>$easyconfig_md

		echo -e "-    [$easyconfig](${easyconfig/.eb/.md})" >>$package_file

	done

	#
	# Generate the techical documentation if a README.md file exists.
	#
    readme="../../easybuild/easyconfigs/$package_dir/README.md"
	if [[ -f $readme ]]
    then
	    echo -e "## Technical documentation\n" >>$package_file
		egrep -v "^# " $readme | sed -e 's|^#|##|' >>$package_file
	fi

    #
	# Finish the package list
	#
    echo -e "\n[[package list]](../../index.md)" >>$package_file


	# Finally add the link to the package list

    [[ $group != $last_group ]] && echo -e "## $group\n" >>$package_list
    last_group="$group"
    
    echo -e "-   [$package]($package_file)\n" >>$package_list

	
done
