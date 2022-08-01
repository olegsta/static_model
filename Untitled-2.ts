// URL and parameters
const url = 'https://ebanoe.it/wp-admin/admin-ajax.php';
const action = 'vortex_system_comment_like_button';
const post_id = 495747;
const nonce = '8b8ed56de0';

// Data to be sent in the request body
const data = new URLSearchParams();
data.append('action', action);
data.append('post_id', post_id);
data.append('nonce', nonce);

// Options for the fetch request
const options = {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Remote-IP': '104.21.90.104:445'
    // Add any other headers if needed
  },
  body: data,
  credentials: 'include', // Include cookies in the request
};

// Send the POST request
fetch(url, options)
  .then(response => response.json())
  .then(data => {
    console.log('Success:', data);
    // Handle the response data here
  })
  .catch(error => {
    console.error('Error:', error);
    // Handle errors here
  });