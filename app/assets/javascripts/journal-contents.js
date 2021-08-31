addJournalInfo = function () {
    $('.journal-contents').each(function(index, element) {
        var url = '/journal_contents_note?journal_name=' + element.getAttribute("journal");
        $.ajax({
            type: "GET",
            url: url,
            contentType: 'text/plain',
            success: function (data) {
                element.innerHTML = data;
            }
        });
    
    });    
}

$(addJournalInfo);