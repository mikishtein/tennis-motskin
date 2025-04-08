const express = require('express');
const stripe = require('stripe')('sk_test_51RAxYBELskPbHO0vHckWloKOLkLoMtcV4T2UFKo8AMYxcjvT983GNN8cmWSaHxkLKQE1ACUOZlr12daDxmQyiiyt005dXzWzJd'); // 🔑 Use your Stripe secret key
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

app.post('/create-payment-intent', async (req, res) => {
  const { amount } = req.body;

  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount,
    currency: 'usd',
    automatic_payment_methods: { enabled: true },
  });

  res.send({
    clientSecret: paymentIntent.client_secret,
  });
});

app.listen(4242, () => console.log('Server running on port 4242'));
