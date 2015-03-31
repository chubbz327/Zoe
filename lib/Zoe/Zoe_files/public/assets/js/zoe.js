$(document).ready(function() {
	console.log("model create template loaded!");
	$("#form_").validate();

});

// number of objects added to request params
var id_inc = 1;

// initialize jquery validator

/*
 * Add the input values whose name contains prefix within div to an object
 * assign object json string to input param
 */
function add_to_request_param(request_param, prefix, object_name,
		to_string_name, hide_add_button) {

	var to_string_val;
	var input_id = request_param + "_INC_" + id_inc;
	// get list of inputs
	var div_id = '#new_' + object_name;
	var previously_added_id = '#previously_added_' + object_name;
	var object = new Object();
	var is_valid = true;
	var file_input_id = '';
	
	var add_div_id = '#new_'+ object_name + '_button';
	/*
	 * assign input values to object keys check validity
	 */
	$(div_id + " :input").each(
			function() {
				if (this.validity.valid === true) {
					var member_name = this.name.replace(prefix, '');

					var file_regex = /file/i;
					if (file_regex.test(this.type)) {
						var member_name_attr_val = $('#' + this.id).attr(
								'member_name');
						member_name = member_name_attr_val.replace(prefix, '');
						file_input_id = this.name;
						object[member_name] = this.id;

						var clone = $('#' + this.id).clone();
						clone.attr({
							id : ''
						});
						var parent = $('#' + this.id).parent();
						$('#' + this.id).appendTo($("#stored_inputs"));
						clone.attr({
							name : member_name_attr_val
						});
						clone.appendTo(parent);

						console.log('Adding file input: ' + file_input_id);
					} else {
						object[member_name] = this.value;
						console.log(JSON.stringify(object));
					}
					if (to_string_name != '0') {
						if (member_name == to_string_name) {
							to_string_val = this.value;
						}
					} else {
						to_string_val = id_inc;
					}
				} else {

					console.log('input ' + this.id
							+ ' failed validation; ERROR: '
							+ this.validationMessage)
					var parent = $('#' + this.id).parent();
					console.log(parent + 'PARENT');
					is_valid = false;
					// $("#form_<%= $object->get_primary_key_value %>").valid();
					$('#' + this.id).valid();
				}
			});
	if (!is_valid) {
		return;
	}
	// assign object values to hidden input
	console.log('Request param ' + request_param + ' = '
			+ JSON.stringify(object));
	$('<input>').attr({
		type : 'hidden',
		id : input_id,
		name : request_param,
		value : JSON.stringify(object),
	}).appendTo(div_id);
	$('<a>').attr(
			{
				href : previously_added_id,
				id : 'a_' + input_id,
				data_file_input_id : file_input_id,
				onclick : "remove_from_request('" + input_id + "' , '" + 'a_'
						+ input_id + "' , '"+ add_div_id +"' )"
			}).appendTo(previously_added_id);
	$('#a_' + input_id).html('Remove ' + to_string_val + '&nbsp;');
	// Clear inputs
	$(div_id + " :input").each(function() {
		var input_obj = $('#' + this.id);
		if (input_obj.attr('type') != 'hidden') {
			input_obj.val('');
			this.value = '';
		}
	});

	// Change the button from hide back to new
	var button_id = '#new_' + object_name + '_button';
	$(button_id).html('New ' + object_name);
	$(div_id).fadeToggle()
	id_inc++;
	if (Boolean(hide_add_button)) {
		
		
		$(add_div_id).hide();
		console.log('Add new div id  ' + add_div_id);
	}
}
function remove_from_request(input_id, a_link_id, add_div_id) {
	var file_input = $('#' + a_link_id).attr('data_file_input_id');
	if (file_input.length > 0) {
		$('#' + file_input).remove();
	}
	$('#' + input_id).remove();
	$('#' + a_link_id).remove();
	console.log('Add new div id  ' + add_div_id);
	$(add_div_id).show();
}
function toggle_add(add_div_id, item_name, button_id) {
	
	var button_text;
	if ($(add_div_id).is(':visible')) {
		button_text = "New " + item_name;
	} else {
		button_text = "Hide " + item_name;
	}

	/*
	 * if file input set the id and the name so tha tth ediv can be hidden
	 */
	$(add_div_id + ' :input').each(function() {
		var file_match = /file/i;

		if ((file_match.test(this.type)) && (!$.trim(this.value).length)) {
			$('#' + this.id).attr({
				member_name : this.name
			});
			this.id = this.name + id_inc;
			this.name = this.id;

		}

	});
	$(button_id).html(button_text);
	$(add_div_id).fadeToggle();
}