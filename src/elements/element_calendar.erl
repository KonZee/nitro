-module(element_calendar).
-author('G-Grand').
-include_lib("nitro/include/nitro.hrl").
-export([render_element/1]).

render_element(Record) ->
    Id = case Record#calendar.postback of
        undefined -> Record#calendar.id;
        Postback ->
          ID = case Record#calendar.id of
            undefined -> nitro:temp_id();
            I -> I end,
          nitro:wire(#event{type=click, postback=Postback, target=ID,
                  source=Record#calendar.source, delegate=Record#calendar.delegate }),
          ID end,

    init(Id,Record),

    List = [
      %global
      {<<"accesskey">>, Record#calendar.accesskey},
      {<<"class">>, Record#calendar.class},
      {<<"contenteditable">>, case Record#calendar.contenteditable of true -> "true"; false -> "false"; _ -> undefined end},
      {<<"contextmenu">>, Record#calendar.contextmenu},
      {<<"dir">>, case Record#calendar.dir of "ltr" -> "ltr"; "rtl" -> "rtl"; "auto" -> "auto"; _ -> undefined end},
      {<<"draggable">>, case Record#calendar.draggable of true -> "true"; false -> "false"; _ -> undefined end},
      {<<"dropzone">>, Record#calendar.dropzone},
      {<<"hidden">>, case Record#calendar.hidden of "hidden" -> "hidden"; _ -> undefined end},
      {<<"id">>, Id},
      {<<"spellcheck">>, case Record#calendar.spellcheck of true -> "true"; false -> "false"; _ -> undefined end},
      {<<"style">>, Record#calendar.style},
      {<<"tabindex">>, Record#calendar.tabindex},
      {<<"title">>, Record#calendar.title},
      {<<"translate">>, case Record#calendar.contenteditable of "yes" -> "yes"; "no" -> "no"; _ -> undefined end},
      % spec
      {<<"autocomplete">>, case Record#calendar.autocomplete of true -> "on"; false -> "off"; _ -> undefined end},
      {<<"autofocus">>,if Record#calendar.autofocus == true -> "autofocus"; true -> undefined end},
      {<<"disabled">>, if Record#calendar.disabled == true -> "disabled"; true -> undefined end},
      {<<"form">>,Record#calendar.form},
      {<<"list">>,Record#calendar.list},
      {<<"name">>,Record#calendar.name},
      {<<"readonly">>,if Record#calendar.readonly == true -> "readonly"; true -> undefined end},
      {<<"required">>,if Record#calendar.required == true -> "required"; true -> undefined end},
      {<<"step">>,Record#calendar.step},
      {<<"type">>, <<"calendar">>},
      {<<"placeholder">>,Record#calendar.placeholder},
      {<<"value">>,nitro:js_escape(Record#calendar.value)} | Record#calendar.data_fields
    ],
    wf_tags:emit_tag(<<"input">>, nitro:render(Record#calendar.body), List).

init(Id,#calendar{minDate=Min,maxDate=Max,lang=Lang,format=Form}) ->
    ID = nitro:to_list(Id),
    I18n = case Lang of
               undefined -> "clLangs.ua";
               Lang -> "clLangs."++nitro:to_list(Lang) end,
    Format = case Form of
                 undefined -> "YYYY-MM-DD";
                 Form -> Form end,
    MinDate = case Min of
                  {Y,M,D} -> nitro:f("new Date(~s,~s,~s)",[nitro:to_list(Y),nitro:to_list(M-1),nitro:to_list(D)]);
                  _ -> "new Date(2000, 0, 1)" end,
    MaxDate = case Max of
                  {Y1,M1,D1} -> nitro:f("new Date(~s,~s,~s)",[nitro:to_list(Y1),nitro:to_list(M1-1),nitro:to_list(D1)]);
                  _ -> "new Date(2087, 4, 13)" end,
    nitro:wire(nitro:f(
        "pickers['~s'] = new Pikaday({
            field: document.getElementById('~s'),
            firstDay: 1,
            i18n: ~s,
            minDate: ~s,
            maxDate: ~s,
            format: '~s'
        });",
        [ID,ID,I18n,MinDate,MaxDate,Format]
    )).