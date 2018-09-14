//= require jquery
//= require rails-ujs
//= require i18n
//= require i18n/translations

//= require analog_admin_template

//= require froala_editor.min
//= require froala_plugins
//= require froala

//= require bootbox.min
//= require datatables
//= require datatables.utils
//= require form.utils

//= require jquery.twzipcode.min

//= require select2.min
//= require decimal.min
//= require cocoon

//= require jquery.datetimepicker.full
//= require jquery-fileupload

//= require common/modals
//= require common/attachments

//= require jquery-ui

//= require photoswipe
//= require photoswipe_init

// 轉浮點數
var toFloat = function(value, precision){
    if( $.isNumeric( value ) ){
        value = parseFloat( value ).toFixed( precision );
    } else {
        value = 0;
    }
    value = parseFloat( value );
    return value;
};

$(function() {
    // 設定 i18n 的語系
    I18n.locale = $('body').data('locale');

    // 讓 ajax request 都會加上 CSRF token
    $.ajaxSetup({
        timeout: 30000,
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        beforeSend: function() {
            NProgress.start();
        },
        complete: function(xhr, stat) {
            NProgress.done();
        },
        error: function(xhr, stat) {
            NProgress.done();
            toastr.error(I18n.t('helpers.ajax.default_error'));
        }
    });

    $(document).on('ajax:before', function(event, xhr, settings){
        NProgress.start();
    });

    $(document).on('ajax:complete', function(event, xhr, status){
        NProgress.done();
    });

    $(document).ajaxError(function(event, request, settings) {
        NProgress.done();
        toastr.error(I18n.t('helpers.ajax.default_error'));
    });

    $.datetimepicker.setLocale(I18n.locale);
    $(".datetimepicker").datetimepicker({ 
        inline: false,
        format: 'Y-m-d H:i',
    });
    $(".datepicker").datetimepicker({ 
        inline: false,
        format: 'Y-m-d',
        timepicker: false,
    });

    $(".select2:not([data-select2])").select2({
        theme: 'bootstrap',
        width: '100%',
        placeholder: I18n.t('helpers.select.prompt'),
        allowClear: true,
    });

    if(('.fr-wrapper > div:first-child > a').length) {
        $('.fr-wrapper > div:first-child > a').remove();
    }

    $('.js-popup-new-window').on('click', function(event) {
        event.preventDefault();
        window.open($(this).attr('href'), "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=250,left=300,width=800,height=400");
    });

    // 讓滑鼠滾輪不影響數值欄位
    $(document).on("wheel", ".numeric", function (e) {
        $(this).blur();
    });
});

$(document).on('ready page:change', function() {
});
