<?php
$lang = null;

switch ($_POST['lang']) {
    case 'en': case 'tr':
        $lang = '_' . $_POST['lang'];
        break;
    
    case 'ar': case '': /* Arabic could be empty */
        $lang = '';
        break;

    default:
        throw new Exception('POST `lang` parameter is empty or incorrect.');
}

try {
    require_once 'mailer/src/Mandrill.php';
    $mandrill = new Mandrill('D-M4hF-tdEV4kv8A_rdgGA');
    $message = array(
        'text' => $_POST['message'],
        'subject' => $_POST['subject'],
        'from_email' => $_POST['email'],
        'from_name' => $_POST['name'],
        'to' => array(
            array(
                'email' => 'ammar@ankaproje.com',
                'name' => 'Findik Suyu Villas',
                'type' => 'to'
            )
        ),
        'headers' => array('Reply-To' => $_POST['email']),
    );
    
    $async = false;
    
    $result = $mandrill->messages->send($message, $async);
    
    if (!empty($result[0]) && !empty($result[0]['reject_reason'])) {
        header("Location: mail-error{$lang}.html");
    } else {
        header("Location: mail-sent{$lang}.html");
    }
    

    
} catch (Mandrill_Error $e) {
    // Mandrill errors are thrown as exceptions
    // echo 'A mandrill error occurred: ' . get_class($e) . ' - ' . $e->getMessage();
    // A mandrill error occurred: Mandrill_Unknown_Subaccount - No subaccount exists with the id 'customer-123'
    header("Location: mail-error{$lang}.html");
    // throw $e;
}
