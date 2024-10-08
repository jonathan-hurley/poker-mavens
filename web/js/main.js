
(function ($) {
	"use strict";
	$('.column100').on('mouseover',function(){
		var table1 = $(this).parent().parent().parent();
		var table2 = $(this).parent().parent();
		var verTable = $(table1).data('vertable')+"";
		var column = $(this).data('column') + "";

		$(table2).find("."+column).addClass('hov-column-'+ verTable);
		$(table1).find(".row100.head ."+column).addClass('hov-column-head-'+ verTable);
	});

	$('.column100').on('mouseout',function(){
		var table1 = $(this).parent().parent().parent();
		var table2 = $(this).parent().parent();
		var verTable = $(table1).data('vertable')+"";
		var column = $(this).data('column') + "";

		$(table2).find("."+column).removeClass('hov-column-'+ verTable);
		$(table1).find(".row100.head ."+column).removeClass('hov-column-head-'+ verTable);
	});


})(jQuery);

$('* span.currency').each(function () {
	var item = $(this).text();
	if (item == "(redacted)") {
		return
	}

	var num = formatCurrency(Number(item))

	if (Number(item) == 0) {
		$(this).addClass('zeroMoney');
	}
	if (Number(item) < 0) {
		num = num.replace('-', '');
		$(this).addClass('negMoney');
	} else {
		$(this).addClass('posMoney');
	}

	num = $(this).text(num);
});

function formatCurrency(value) {
	formatOptions = {
		style: 'currency',
		currency: "USD",
		currencyDisplay: 'symbol',
	}

	let result = Intl.NumberFormat("en", formatOptions).format(value)
		// strip symbols
	result = result.replace(/[\$]/i, "").trim()
	return result
}

$('.js-pscroll').each(function () {
	var ps = new PerfectScrollbar(this);

	$(window).on('resize', function () {
		ps.update();
	})
});

$('* span.percentage').each(function () {
	var item = $(this).text();
	if (item == "(redacted)") {
		return
	}

	var decimal = Number(item/100)
	var num = decimal.toLocaleString(undefined,{style: 'percent', minimumFractionDigits:2}); 

	if (Number(item) < 0) {
		$(this).addClass('negPercentage');
	} else {
		$(this).addClass('posPercentage');
	}
	
	num = $(this).text(num);
});

