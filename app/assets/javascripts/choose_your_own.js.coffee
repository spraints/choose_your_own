jQuery ->
  $ = jQuery
  $('body').delegate '.choose_your_own > .menu > .menu_item', 'click', ->
    $this = $(this)
    $this.closest('.menu').children().removeClass('active')
    $this.addClass('active')
    top = $this.closest('.choose_your_own')
    top.children().removeClass('active')
    top.children("##{this.id.replace('menu_for_','')}").addClass('active')
    top.children('input').val($this.data('value'))
