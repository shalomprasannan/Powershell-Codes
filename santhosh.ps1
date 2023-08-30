$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8081/")
$listener.Start()
$request=@{}
$response=@{}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Set the content type and response content
        $response.ContentType = "text/plain"
        $responseString = "Hello, this is a sample server response!"

        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)

        $response.OutputStream.Flush()
        $response.Close()
    }
}
finally {
    $listener.Stop()
    $listener.Close()
}
