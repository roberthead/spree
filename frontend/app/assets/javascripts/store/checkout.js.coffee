Spree.disableSaveOnClick = ->
  ($ 'form.edit_order').submit ->
    ($ this).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass 'disabled'

Spree.Checkout = {}

Spree.ready ($) ->
  if ($ '#checkout_form_address').is('*')
    ($ '#checkout_form_address').validate()

    getCountryId = (region) ->
      $('p#' + region + 'country select').val()

    updateState = (region) ->
      countryId = getCountryId(region)
      if countryId?
        unless Spree.Checkout[countryId]?
          $.get Spree.routes.states_search, {country_id: countryId}, (data) ->
            Spree.Checkout[countryId] =
              states: data.states
              states_required: data.states_required
            fillStates(Spree.Checkout[countryId], region)
        else
          fillStates(Spree.Checkout[countryId], region)

    fillStates = (data, region) ->
      statesRequired = data.states_required
      states = data.states

      statePara = ($ 'p#' + region + 'state')
      stateSelect = statePara.find('select')
      stateInput = statePara.find('input')
      stateSpanRequired = statePara.find('state-required')
      if states.length > 0
        selected = parseInt stateSelect.val()
        stateSelect.html ''
        statesWithBlank = [{ name: '', id: ''}].concat(states)
        $.each statesWithBlank, (idx, state) ->
          opt = ($ document.createElement('option')).attr('value', state.id).html(state.name)
          opt.prop 'selected', true if selected is state.id
          stateSelect.append opt

        stateSelect.prop('disabled', false).show()
        stateInput.hide().prop 'disabled', true
        statePara.show()
        stateSpanRequired.show()
      else
        stateSelect.hide().prop 'disabled', true
        stateInput.show()
        if statesRequired
          stateSpanRequired.show()
        else
          stateInput.val ''
          stateSpanRequired.hide()
        statePara.toggle(!!statesRequired)
        stateInput.prop('disabled', !statesRequired)

    ($ 'p#bcountry select').change ->
      updateState 'b'
      if $('input#order_use_billing').is(':checked')
        countryId = $('#bcountry select').val()
        $('#scountry select').val(countryId).change()

    ($ 'p#bstate input').change ->
      if $('input#order_use_billing').is(':checked')
        $('#sstate input').val($('#sstate input').val())

    ($ 'p#bstate select').change ->
      console.log("triggering right field")
      if $('input#order_use_billing').is(':checked')
        $('p#sstate select').val($('#bstate select').val())


    ($ 'p#scountry select').change ->
      updateState 's'

    updateState 'b'
    updateState 's'

    ($ 'input#order_use_billing').change(->
      if ($ this).is(':checked')
        ($ '#shipping .inner').hide()
        ($ '#shipping .inner input, #shipping .inner select').prop 'disabled', true
      else
        ($ '#shipping .inner').show()
        ($ '#shipping .inner input, #shipping .inner select').prop 'disabled', false
        updateState('s')
    ).triggerHandler 'change'

  if ($ '#checkout_form_payment').is('*')
    ($ 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]').click(->
      ($ '#payment-methods li').hide()
      ($ '#payment_method_' + @value).show() if @checked
    )

    ($ document).on('click', '#cvv_link', (event) ->
      windowName = 'cvv_info'
      windowOptions = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1'
      window.open(($ this).attr('href'), windowName, windowOptions)
      event.preventDefault()
    )

    # Activate already checked payment method if form is re-rendered
    # i.e. if user enters invalid data
    ($ 'input[type="radio"]:checked').click()
