public with sharing class HttpFormBuilderUtility {
    //  The boundary is alligned so it doesn't produce padding characters when base64 encoded.
    private final static string Boundary = '1ff13444ed8140c7a32fc4e6451aa76d';

    /**
     *  Returns the request's content type for multipart/form-data requests.
     */
    public static string getContentType() {
        return 'multipart/form-data; charset="UTF-8"; boundary="' + Boundary + '"';
    }

    /**
     *  Pad the value with spaces until the base64 encoding is no longer padded.
     */
    private static String safelyPad(String value, String valueCrLf64, String lineBreaks) {
        String valueCrLf = '';
        Blob valueCrLfBlob = null;
        
		System.debug(' valueCrLf64 '+valueCrLf64);
        /*if(valueCrLf64.endsWith('==')){
            valueCrLf = value + lineBreaks;
             valueCrLfBlob = blob.valueOf(valueCrLf);
             valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
        }else{ */
            while (valueCrLf64.endsWith('=') ) {
                System.debug(' valueCrLf64 IN '+valueCrLf64);
                value += ' ';
                System.debug(value);
                valueCrLf = value + lineBreaks;
                System.debug(' valueCrLf IN '+valueCrLf);
                valueCrLfBlob = blob.valueOf(valueCrLf);
                System.debug(' valueCrLfBlob IN '+valueCrLfBlob);
                valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
                 System.debug(' valueCrLf64 IN '+valueCrLf64);
           // }
        }
    
	System.debug(' valueCrLf64 OUT '+valueCrLf64);
        return valueCrLf64;
    }

    /**
     *  Write a boundary between parameters to the form's body.
     */
    public static string writeBoundary() {
        String value = '--' + Boundary + '\r\n';
        Blob valueBlob = blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     *  Write a boundary at the end of the form's body.
     */
    public static String writeBoundary(EndingType ending) {
        String value = '';

        if (ending == EndingType.Cr) {
            //  The file's base64 was padded with a single '=',
            //  so it was replaced with '\r'. Now we have to
            //  prepend the boundary with '\n' to complete
            //  the line break.
            value += '\n';
        } else if (ending == EndingType.None) {
            //  The file's base64 was not padded at all,
            //  so we have to prepend the boundary with
            //  '\r\n' to create the line break.
            value += '\r\n';
        }
        //  Else:
        //  The file's base64 was padded with a double '=',
        //  so they were replaced with '\r\n'. We don't have to
        //  do anything to the boundary because there's a complete
        //  line break before it.

        value += '--' + Boundary + '--';

        Blob valueBlob = Blob.valueOf(value);

        return EncodingUtil.base64Encode(valueBlob);
    }

    /**
     *  Wirte a file to the form's body.
     */
    public static WriteFileResult writeFile(String key, String value, String mimeType, Blob fileBlob) {
        EndingType ending = EndingType.None;
        String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"; filename="' + value + '"';
        String contentDispositionCrLf = contentDisposition + '\r\n';
        Blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
        String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrlfBlob);
        String content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n');
        String contentType = 'Content-Type: ' + mimeType;
        String contentTypeCrLf = contentType + '\r\n\r\n';
        Blob contentTypeCrLfBlob = blob.valueOf(contentTypeCrLf);
        String contentTypeCrLf64 = EncodingUtil.base64Encode(contentTypeCrLfBlob);

        content += SafelyPad(contentType, contentTypeCrLf64, '\r\n\r\n');

        String file64 = EncodingUtil.base64Encode(fileBlob);
        Integer file64Length = file64.length();
        String file64Ending = file64.substring(file64Length - 3, file64Length);

        if (file64Ending.endsWith('==')) {
            file64Ending = file64Ending.substring(0, 1) + '0K';//   0K = \r\n
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.CrLf;
        } else if (file64Ending.endsWith('=')) {
            file64Ending = file64Ending.substring(0, 2) + 'N';//    N = \r
            file64 = file64.substring(0, file64Length - 3) + file64Ending;
            ending = EndingType.Cr;
        }

        content += file64;

        return new WriteFileResult(content, ending);
    }

    /**
     *  Write a key-value pair to the form's body.
     */
    public static String writeBodyParameter(
        String key,
        String value) {
            System.debug('Test '+key);
            String contentDisposition = 'Content-Disposition: form-data; name="' + key + '"';
            System.debug('contentDisposition '+contentDisposition);
            String contentDispositionCrLf = contentDisposition + '\r\n\r\n';
            System.debug('contentDispositionCrLf '+contentDispositionCrLf);
            Blob contentDispositionCrLfBlob = blob.valueOf(contentDispositionCrLf);
            System.debug('contentDispositionCrLfBlob '+contentDispositionCrLfBlob);
            String contentDispositionCrLf64 = EncodingUtil.base64Encode(contentDispositionCrLfBlob);
            System.debug('contentDispositionCrLf64 '+contentDispositionCrLf64);
            String content = SafelyPad(contentDisposition, contentDispositionCrLf64, '\r\n\r\n');
            System.debug('content '+content);
            String valueCrLf = value + '\r\n';
            System.debug('valueCrLf '+valueCrLf);
            Blob valueCrLfBlob = blob.valueOf(valueCrLf);
            System.debug('valueCrLfBlob '+valueCrLfBlob);
            String valueCrLf64 = EncodingUtil.base64Encode(valueCrLfBlob);
            System.debug('valueCrLf64 '+ key +' '+ valueCrLf64);
            
            content += SafelyPad(value, valueCrLf64, '\r\n'); 
            
            System.debug('content '+content);
            return content;
    }

    /**
     *  Helper class containing the result of writing a file's blob to the form's body.
     */
    public class WriteFileResult {
        public final String Content { get; private set; }
        public final EndingType EndingType { get; private set; }

        public WriteFileResult(String content, EndingType ending) {
            this.Content = content;
            this.EndingType = ending;
        }
    }

    /**
     *  Helper enum indicating how a file's base64 padding was replaced.
     */
    public Enum EndingType {
        Cr,
        CrLf,
        None
    }
}