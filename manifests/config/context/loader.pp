# Definition: tomcat::config::context::loader
#
# Configure Loader elements in $CATALINA_BASE/conf/context.xml
#
# Parameters:
# - $catalina_base is the base directory for the Tomcat installation.
# - $ensure specifies whether you are trying to add or remove the
#   Loader element. Valid values are 'true', 'false', 'present', and
#   'absent'. Defaults to 'present'.
# - $loader_class is the name of the loaderClass to be created
# - An optional hash of $additional_attributes to add to the Loader. Should
#   be of the format 'attribute' => 'value'.
# - An optional array of $attributes_to_remove from the Loader.
define tomcat::config::context::loader (
  $ensure                = 'present',
  $loader_class          = $name,
  $catalina_base         = $::tomcat::catalina_home,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  if $loader_class {
    $_loader_class = $loader_class
  } else {
    $_loader_class = $name
  }

  $base_path = "Context/Loader[#attribute/loaderClass='${_loader_class}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    # (MODULES-3353) does this need to be quoted?
    $set_name = "set ${base_path}/#attribute/loaderClass ${_loader_class}"

    if ! empty($additional_attributes) {
      $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $rm_attributes_to_remove = undef
    }


    $changes = delete_undef_values(flatten([
      $set_name,
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-loader-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
