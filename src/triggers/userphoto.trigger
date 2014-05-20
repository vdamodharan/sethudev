trigger userphoto on User (after update) {
	system.debug('Trigger.new[0].FullPhotoURL ' + Trigger.new[0].FullPhotoURL);
}