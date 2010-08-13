(function($) {
	// Enable sortable items
	$(function() {
		// ==================
		// Sortable
		$('[data-sortable]').sortable({axis:'y', 
																	  dropOnEmpty:false, 
																	  update: function(event, ui) {
																			sortable = this;
																			$.ajax({data:$(this).sortable('serialize',{key:sortable.id + '[]'}),
																							complete: function(request) {$(sortable).effect('highlight')}, 
																							success:function(request){$('#errors').html(request)}, 
																							type:'put', 
																							url: $(sortable).attr('data-sortable-url')
																						 })
																			}
																		})
		$('[data-sortable][data-sortable-handle]').each(function() {
			handle = $(this).attr('data-sortable-handle');
			$(this).sortable("option", "handle", handle);
		});
		// ==================
		
		// ==================
		// Calendar
    $('[data-calendar]').datepicker({changeYear:true,
																		 yearRange: '1975:c+5'})
  	// ==================
	});			
})(jQuery);