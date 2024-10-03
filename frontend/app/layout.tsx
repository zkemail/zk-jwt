import type { Metadata } from "next";
import { ChakraProvider } from "@chakra-ui/react";
import localFont from "next/font/local";
import "./globals.css";

const geistSans = localFont({
    src: "./fonts/GeistVF.woff",
    variable: "--font-geist-sans",
    weight: "100 900",
});
const geistMono = localFont({
    src: "./fonts/GeistMonoVF.woff",
    variable: "--font-geist-mono",
    weight: "100 900",
});

export const metadata: Metadata = {
    title: "JWT-Wallet",
    description: "A simple JWT wallet application",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en">
            <body className={`${geistSans.variable} ${geistMono.variable}`}>
                <ChakraProvider>{children}</ChakraProvider>
                <script
                    src="https://accounts.google.com/gsi/client"
                    async
                    defer
                ></script>
            </body>
        </html>
    );
}
