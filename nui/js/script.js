/**
 * ===================================================
 * ===================================================
 *                    IR8 FRAMEWORK
 * ===================================================
 * ===================================================
 */

const IR8 = {

    /**
     * State object for script
     */
    state: {
        tickets: [],
        categories: [],
        statuses: [],
        disclaimer: false
    },

    /**
     * Current event being fired
     */
    currentEvent: false,

    /**
     * Resource name, set in init
     */
    resourceName: 'ir8-tickets',

    /**
     * Debugging
     */
    debug: false,

    /**
     * Admin privs
     */
    isAdmin: false,

    /**
     * Debug printing
     */
    debugPrint (txt) {
        if (IR8.debug) {
            console.log(typeof txt == 'object' || Array.isArray(txt) ? JSON.stringify(txt) : txt);
        }
    },

    /**
     * General NUI request, async available.
     */
    nuiRequest: async (path, data = {}) => {

        // Support for stringified json objects being passed
        if (typeof data == "string") {
            data = JSON.parse(decodeURIComponent(data))
        }

        IR8.debugPrint(`Invoking NUI Request[${path}] with the following data:`);
        IR8.debugPrint(data);
    
        return $.ajax({
            url: `https://${GetParentResourceName()}/${path}`,
            type: 'POST',
            dataType: 'json',
            data: JSON.stringify(data)
        });
    },

    /**
     * Message handler for NUI events
     */
    messageHandler: (e) => {

        // Set the current event
        currentEvent = event;

        // If data action is not provided
        if (!e.data.action) {
            IR8.debugPrint(`Message received, but not action present.`)
            return false;
        } 

        if (IR8.handlers[e.data.action]) {
            if (typeof IR8.handlers[e.data.action] == "function") {
                IR8.debugPrint(`Invoking Event[${event.data.action}]`);
                return IR8.handlers[e.data.action](e.data);
            }
        }

        return IR8.debugPrint(`Event[${event.data.action}] called, but no handler for event is present.`);
    },

    /**
     * Events to run on document ready.
     */
    readyEvents: () => {

        IR8.nuiRequest('ready');

        // Close button in header
        $('.actionable').on('click', function () {
            IR8.nuiRequest('hide');
        })

        // When esc key is pressed
        $(document).on("keyup", function(e) {
            if (e.key == "Escape") {
                IR8.nuiRequest('hide');
            }
        });
    },

    /**
     * Shows Main Alert
     * 
     * Must have the following in index somewhere for this function to work:
     * 
     * <div class="alert alert-danger" style="display: none;" id="main-alert" role="alert"></div>
     */
    showMainAlert: (txt, type = "danger") => {
        if ($('#main-alert').length) {
            $('#main-alert').hide();

            $('#main-alert')
                .removeClass('alert-danger')
                .removeClass('alert-warning')
                .removeClass('alert-success');
            
            $('#main-alert').addClass(`alert-${type}`);
            $('#main-alert').html(txt).show();
        }
    },

    /**
     * Shows alert
     * 
     * Must have the following in index somewhere for this function to work:
     * 
     * <div class="alert alert-danger" style="display: none;" id="view-alert" role="alert"></div>
     */
    showViewAlert: (txt, type = "danger") => {
        if ($('#view-alert').length) {
            $('#view-alert').hide();

            $('#view-alert')
                .removeClass('alert-danger')
                .removeClass('alert-warning')
                .removeClass('alert-success');
            
            $('#view-alert').addClass(`alert-${type}`);
            $('#view-alert').html(txt).show();
        }
    },

    /**
     * Shows alert
     * 
     * Must have the following in index somewhere for this function to work:
     * 
     * <div class="alert alert-danger" style="display: none;" id="alert" role="alert"></div>
     */
    showAlert: (txt, type = "danger") => {
        if ($('#alert').length) {
            $('#alert').hide();

            $('#alert')
                .removeClass('alert-danger')
                .removeClass('alert-warning')
                .removeClass('alert-success');
            
            $('#alert').addClass(`alert-${type}`);
            $('#alert').html(txt).show();
        }
    },

    /**
     * Sets theme data for the dom
     */
    setTheme: (data) => {
    

        /**
         * Handle custom theme
         */
        if (data.theme) {
    
            if (data.theme.Title) {
                
                if (IR8.isAdmin) {
                    $('.title-container > .title').html(data.theme.Title.Admin)
                } else {
                    $('.title-container > .title').html(data.theme.Title.Player)
                }
            }
    
            if (data.theme.Colors.Background) {
                $('#modal .modal-content').css('background-color', data.theme.Colors.Background);
            }
    
            if (data.theme.Colors.Text) {
                $('body').css('color', data.theme.Colors.Text);
                $('.action').css('color', data.theme.Colors.Text);
            }
        }
    },

    /**
     * Sets categories for tickets
     */
    setCategories: () => {
        if (IR8.state.categories.length) {
            $('#category').html('');
            IR8.state.categories.forEach((category, index) => {
                $('#category').append(`<option value="${category}">${category}</option>`);
            });
        }
    },

    /**
     * Hides/shows disclaimer message before submission of ticket
     * if enabled in the config
     */
    setDisclaimer: () => {

        // Show disclaimer if there is one.
        if (IR8.state.disclaimer !== false) {
            $('#disclaimer').html(`<div class="alert alert-info" role="alert">${IR8.state.disclaimer}</div>`);
        } else {
            $('#disclaimer').html('');
        }
    },

    /**
     * Finds the status data for a specific data
     * and returns the object
     */
    getStatusData: (status) => {
        let statusData = false;

        for (let i = 0; i < IR8.state.statuses.length; i++) {
            if (status.toLowerCase() == IR8.state.statuses[i].label.toLowerCase()) {
                statusData = IR8.state.statuses[i];
            }
        }

        return statusData;
    },

    /**
     * Handles writing ticket replies to the dom
     */
    handleReplies: (replies) => {
        $('#replies').html('');

        if (Array.isArray(replies)) {
            if (replies.length) {
                replies.forEach((reply, index) => {
                    $('#replies').append(
                        `
                            <div class="card w-100 mt-3">
                                <div class="card-body">
                                <p class="card-text">${reply.name}: ${reply.message}</p>
                                </div>
                            </div>
                        `
                    )
                })
            }
        }
    },

    /**
     * Loads ticket data
     */
    loadTicket: async (id) => {
        const res = await IR8.nuiRequest('ticket', {
            id: id
        });

        /**
         * If a successful response was not returned.
         */
        if (!res.success) {
            return IR8.showMainAlert('Unable to retrieve ticket information for ticket ' + id, 'error');
        }

        /**
         * Get dom elements we need to alter
         */
        const ticketId = $('#ticket-id');
        const ticketTitle = $('#ticket-title');
        const ticketMessage = $('#ticket-message');
        const ticketName = $('#ticket-name');

        /**
         * If is admin, show the status setter
         */
        if (IR8.isAdmin) {
            const buttonTicketStatus = $('#ticket-status');
            const buttonTicketStatuses = $('#ticket-statuses');

            buttonTicketStatus.html(res.status);
            buttonTicketStatuses.html('');
            IR8.state.statuses.forEach((status, index) => {
                buttonTicketStatuses.append(
                    `<li><a class="dropdown-item" href="javascript:void(0);" onclick="IR8.updateTicketStatus(${res.id}, '${status.label}');">${status.label}</a></li>`
                )
            })

            $('#ticket-status-container').show();
        } else {
            $('#ticket-status-container').hide();
        }

        /**
         * Set general ticket data
         */
        ticketId.html('Ticket: #' + res.id);
        ticketTitle.html(res.title);
        ticketMessage.html(res.message);

        /**
         * If position is shared and is admin
         */
        if (IR8.isAdmin && res.position) {
            const position = JSON.parse(res.position);

            ticketMessage.append(
                `<hr /><div style="text-align: center;">Position specified for ticket:<br /><a href="javascript:void(0);" onclick="IR8.teleport(${position.x}, ${position.y}, ${position.z})" class="btn btn-primary btn-sm w-100"><i class="fas fa-location-arrow"></i>&nbsp;&nbsp;Teleport to Position</a><br /><div style="font-size: 9px;width: 100%;text-align: center;">${position.x}, ${position.y}, ${position.z}</div></div>`
            )
        }

        /**
         * Sets the data-id attribute for the reply submit button
         */
        $('#reply-submit').data('id', res.id)

        /**
         * If there are replies, write them to the dom
         */
        if (res.replies) {
            IR8.handleReplies(res.replies);
        }

        /**
         * If a name is set, show it
         */
        if (res.name) {
            ticketName.html(`Submitted by: ${res.name}`).show();
        } else {
            ticketName.html('').hide();
        }

        // Check if status allows replies.
        const statusData = IR8.getStatusData(res.status);
        if (statusData) {
            if (statusData.allowReplies === true) {
                $('#reply-form').show();
            } else {
                $('#reply-form').hide();
            }
        } else {
            $('#reply-form').hide();
        }

        /**
         * Hide/show certain elements
         */
        $('#form').hide();
        $('#view-ticket').show();
        $('#modal .modal-side').show();
    },

    /**
     * Handles reply submission to a ticket
     */
    reply: async (id, message) => {
        if (!id) {
            return IR8.showViewAlert('There was an issue with replying. Please try again.');
        }

        if (!message) {
            return IR8.showViewAlert('You must provide a message in your reply.');
        }

        const res = await IR8.nuiRequest('reply', {
            ticket_id: id,
            message: message
        });

        if (!res.success) {
            return IR8.showViewAlert('There was an issue with replying. Please try again.');
        }

        $('#reply').val('');
        await IR8.loadTicket(id);
    },

    /**
     * Handles the updating of a ticket status
     */
    updateTicketStatus: async (id, status) => {
        const res = await IR8.nuiRequest('status', {
            id: id,
            status: status
        });

        if (!res.success) {
            return IR8.showViewAlert('There was an issue updating the status. Please try again.');
        }

        await IR8.loadTicket(id);
    },

    /**
     * Resets a form
     */
    resetForm: () => {
        $('#title').val('');
        $('#category').val('General');
        $('#message').val('');
    },

    /**
     * Sends teleport request to the resource
     */
    teleport: (x, y, z) => {
        IR8.nuiRequest('teleport', { x, y, z });
    },

    /**
     * Default handlers
     * 
     * You can override defaults. Example: IR8.handlers.init = () => {}
     */
    handlers: {

        init: (data) => {
    
            if (data.debug) {
                IR8.debug = data.debug
                IR8.debugPrint("Setting debug to " + data.debug);
            }

            if (typeof data.admin !== 'undefined') {
                IR8.isAdmin = data.admin;
                IR8.debugPrint("Setting isAdmin to " + data.admin);
            }

            if (typeof data.ticketConfiguration !== 'undefined') {

                if (typeof data.ticketConfiguration.Categories !== 'undefined') {
                    IR8.state.categories = data.ticketConfiguration.Categories;
                    IR8.debugPrint("[Ticket Configuration] Setting categories");
                }

                if (typeof data.ticketConfiguration.Statuses !== 'undefined') {
                    IR8.state.statuses = data.ticketConfiguration.Statuses;
                    IR8.debugPrint("[Ticket Configuration] Setting statuses");
                }

                if (typeof data.ticketConfiguration.Disclaimer !== "undefined") {
                    IR8.state.disclaimer = data.ticketConfiguration.Disclaimer;
                    IR8.debugPrint("[Ticket Configuration] Setting disclaimer");
                }
            }
        },
    },
}

/**
 * ===================================================
 * ===================================================
 *                      NUI LOGIC
 * ===================================================
 * ===================================================
 */

/**
 * Main NUI Element to show or hide
 */
const mainNuiElement = '#modal';

/**
 * ===================================================
 * MESSAGE EVENT HANDLERS
 * ===================================================
 */
IR8.handlers.show = (data) => {

    if (data.theme) {
        IR8.setTheme(data);
    }

    // Reset privs in case group has changed
    if (typeof data.admin !== 'undefined') {
        IR8.isAdmin = data.admin;
        IR8.debugPrint("Setting isAdmin to " + data.admin);
    }

    // Reset categories in case they've changed since last open
    IR8.setCategories();

    // Reset disclaimer in case it has changed since last open
    IR8.setDisclaimer();

    $(mainNuiElement).css({ display: 'flex' });
}

/**
 * Hides UI
 */
IR8.handlers.hide = () => {
    $(mainNuiElement).fadeOut();
}

/**
 * Displays Tickets 
 */
IR8.handlers.tickets = (data) => {

    if (data.tickets) {
        IR8.state.tickets = data.tickets;

        $('#tickets-list').html('');

        if (IR8.state.tickets.length == 0) {
            return $('#tickets-list').html(`
                <tr>
                    <td colspan="5">No tickets to list at this time.</td>
                </tr>
            `);
        }

        IR8.state.tickets.forEach((item, key) => {

            const status = item.status.toLowerCase();
            let badgeType = "default";

            for (let i = 0; i < IR8.state.statuses.length; i++) {
                if (status == IR8.state.statuses[i].label.toLowerCase()) {
                    badgeType = IR8.state.statuses[i].badgeType;
                }
            }

            $('#tickets-list').append(`
                <tr>
                    <td>${item.id}</td>
                    <td><b>${item.title}</b></td>
                    <td>${item.category}</td>
                    <td><span class="badge text-bg-${badgeType}">${item.status.charAt(0).toUpperCase() + item.status.slice(1)}</span></td>
                    <td class="text-end">
                        <a href="javascript:void(0);" onclick="IR8.loadTicket(${item.id});" class="btn btn-primary">View</a>
                    </td>
                </tr>
            `);
        });
    }
}

$(document).ready(function () {
    IR8.readyEvents();

    /**
     * ======================================
     * ADDITIONAL READY EVENTS
     * ======================================
     */

    // Opens the creation/modification form
    $('#open-form').on('click', function (e) {
        e.preventDefault();
        $('#view-ticket').hide();
        $('#form').show();
        $('#modal .modal-side').show();
    })

    // Closes the creation/modification form
    $('#close-form').on('click', function (e) {
        e.preventDefault();
        $('#modal .modal-side').hide();
        $('#view-ticket').hide();
        $('#form').hide();
    })

    $('#refresh-tickets').on('click', function (e) {
        e.preventDefault();
        IR8.nuiRequest('tickets');
    })

    /**
     * ======================================
     * REPLY HANDLER
     * ======================================
     */

    $('#reply-submit').on('click', function () {
        const id = $(this).data('id');
        const message = $('#reply').val();
        IR8.reply(id, message);
    })

    /**
     * ======================================
     * TICKET FORM SUBMISSION
     * ======================================
     */

    // Submits the form
    $('#form').on('submit', async function (e) {
        e.preventDefault();

        // Get all vars
        const title = $('#title').val();
        const category = $('#category').val();
        const message = $('#message').val();

        if (!title) {
            return IR8.showAlert("The title is required.");
        }

        if (!category) {
            return IR8.showAlert("The category is required.");
        }

        if (!message) {
            return IR8.showAlert("The message is required.");
        }

        let position = false;
        if ($('#position').is(':checked')) {
            position = true;
        }

        // Create the data object
        const data = {
            title,
            category,
            message,
            position
        }

        IR8.debugPrint(JSON.stringify(data));
        const res = await IR8.nuiRequest('create', data);

        if (!res.success) {

            if (res.error) {
                return IR8.showAlert(res.error);
            } else {
                return IR8.showAlert("Unable to create ticket. Please try again");
            }
        }

        $('#form').hide();
        $('#modal .modal-side').hide();
        IR8.resetForm();

        return IR8.showMainAlert("Ticket was created successfully", 'success');
    })
});

/**
 * ===================================================
 * MESSAGE EVENT HANDLER SETUP
 * ===================================================
 */
window.addEventListener('message', function(event){
    IR8.messageHandler(event)
});