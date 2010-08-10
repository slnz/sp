(function($) {
	// Enable sortable items
	$(function() {
		$('[data-sortable]').sortable({axis:'y', 
																	  dropOnEmpty:false, 
																		handle: $(this).attr('data-sortable-handle'),
																	  update: function(event, ui) {
																			sortable = this;
																			$.ajax({data:$(this).sortable('serialize',{key:sortable.id + '[]'}),
																							complete: function(request) {$(sortable).effect('highlight')}, 
																							success:function(request){$('#errors').html(request)}, 
																							type:'put', 
																							url: $(sortable).attr('data-sortable-url')
																						 })
																			}
																		});
    $('[data-calendar]').datepicker({changeYear:true,
																		 yearRange: '1975:c+5'})
	});			
})(jQuery);