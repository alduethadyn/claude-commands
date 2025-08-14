## Email Attachment Preview in Conversation View

### Project Information
**Project:** EM  
**Priority:** Medium  
**Labels:**   
**Parent:**   
**Assignee:** ASSIGNEE_NAME

## Description

Support agents currently need to download email attachments to view their contents, which slows down ticket resolution and creates friction in the support workflow. This impacts agent productivity and increases response times for customers.

The solution will implement inline preview functionality for common attachment types (images, PDFs, text files) directly within the conversation view, allowing agents to quickly assess attachment contents without leaving the interface or downloading files.

## References and Notes

### Code Context
* [app/models/email_attachment.rb#L15-L30](https://github.com/zendesk/support/blob/main/app/models/email_attachment.rb#L15-L30) - Current attachment handling logic
* [app/views/conversations/_message.html.erb#L45-L60](https://github.com/zendesk/support/blob/main/app/views/conversations/_message.html.erb#L45-L60) - Message display template where previews will be integrated
* [app/services/attachment_processor.rb#L80-L95](https://github.com/zendesk/support/blob/main/app/services/attachment_processor.rb#L80-L95) - File type validation and processing service
* [app/controllers/attachments_controller.rb#L25-L40](https://github.com/zendesk/support/blob/main/app/controllers/attachments_controller.rb#L25-L40) - Attachment serving and security checks
* [app/assets/javascripts/conversation_view.js#L120-L135](https://github.com/zendesk/support/blob/main/app/assets/javascripts/conversation_view.js#L120-L135) - Client-side attachment handling
* [lib/file_preview/pdf_renderer.rb#L10-L25](https://github.com/zendesk/support/blob/main/lib/file_preview/pdf_renderer.rb#L10-L25) - PDF thumbnail generation utility

### Testing Considerations
* Unit tests needed for `AttachmentPreviewService`
* Integration test scenarios with **various file types and sizes**
* Performance testing for `large PDF files` (>10MB)
* Browser compatibility testing for preview rendering

## Acceptance Criteria

* Support agents can view image attachments (PNG, JPG, GIF) inline without downloading
* PDF attachments display first page preview with `View Full PDF` option
* Text file contents are displayed in a collapsible code block with `syntax highlighting`
* File size limits prevent preview for attachments over **25MB**
* Error handling displays appropriate fallback message for [unsupported file types](https://docs.zendesk.com/agent/help/working-with-tickets/using-tickets/adding-attachments-to-tickets/)
* Preview loading states show **proper spinner indicators**