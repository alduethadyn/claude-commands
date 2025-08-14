# Fix followup ticket plain text formatting bug

**Project:** EM
**Priority:** Medium
**Labels:** bug, email, followup-tickets
**Components:** email
**Assignee:** ENV['JIRA_EMAIL']

## Description

### Background
Some followup tickets are being created with no line breaks when running in plain text mode. This formatting issue affects ticket readability and user experience. The bug appears to be related to how the description is being pulled from old tickets coupled with an ordering problem in the ticket creation process.

### Proposed Solution
The fix involves two main changes:
1. Remove the if case on lines 96/97 in ticket_creator_processor.rb, leaving only the elsif condition
2. Address the ordering issue in ticket_creator_processor where the order of operations may matter when setting state.ticket.description. The description= method in ticket.rb may be overwriting the plain comment value set by the Followup#add_comment method.

## References and Notes

*   *Code Context:*
    *   *[components/email/lib/zendesk/inbound_mail/processors/ticket_creator_processor.rb#L96-L97](https://github.com/zendesk/zendesk/blob/main/components/email/lib/zendesk/inbound_mail/processors/ticket_creator_processor.rb#L96-L97)*
    *   *[components/email/lib/zendesk/inbound_mail/ticketing/followup.rb](https://github.com/zendesk/zendesk/blob/main/components/email/lib/zendesk/inbound_mail/ticketing/followup.rb)*

*   *Related Tickets/Docs:*
    *   *This bug specifically affects the email_fix_plain_text_followup_formatting feature flag behavior*

*   *Testing Considerations:*
    *   *Test followup ticket creation in both plain text and rich text modes*
    *   *Verify line breaks are preserved in plain text followup tickets*
    *   *Test the ordering of description setting vs comment addition*
    *   *Regression testing for existing followup ticket functionality*

*   *Rollout/Deployment:*
    *   *This fix affects the email_fix_plain_text_followup_formatting feature flag behavior*
    *   *Monitor followup ticket creation after deployment for proper formatting*
    *   *Low risk change - isolated to followup ticket creation logic*

*   *Other Notes:*
    *   *The bug is suspected to be caused by the interaction between ticket.description= method and Followup#add_comment method*
    *   *Order of operations in ticket_creator_processor may be critical to preserving formatting*

## Acceptance Criteria

*   *Followup tickets created in plain text mode maintain proper line breaks and formatting*

*   *The if condition on lines 96/97 in ticket_creator_processor.rb is removed, leaving only the elsif condition*

*   *The ordering issue between state.ticket.description setting and Followup#add_comment is resolved*

*   *Existing followup ticket functionality remains unaffected*

*   *Unit and integration tests are updated to cover the fixed behavior*

*   *No regression in rich text followup ticket creation*

*   *Feature flag email_fix_plain_text_followup_formatting continues to work as expected*